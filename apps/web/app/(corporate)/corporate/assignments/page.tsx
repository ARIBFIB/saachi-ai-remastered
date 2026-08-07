"use client";

import { useState } from "react";
import { useCorporateStore } from "@saachi/store";
import { DUMMY_COURSES } from "@saachi/api-client";
import { Button, Card, Select, Badge, EmptyState } from "@saachi/ui";
import { Users } from "lucide-react";

export default function CourseAssignmentPage() {
  const { team, assignCourse } = useCorporateStore();
  const [selectedMemberId, setSelectedMemberId] = useState(team[0]?.id ?? "");
  const [selectedCourseId, setSelectedCourseId] = useState(DUMMY_COURSES[0]?.id ?? "");

  const memberOptions = team.map((m) => ({ label: m.name, value: m.id }));
  const courseOptions = DUMMY_COURSES.map((c) => ({ label: c.title, value: c.id }));

  const handleAssign = () => {
    if (!selectedMemberId || !selectedCourseId) return;
    assignCourse(selectedMemberId, selectedCourseId);
  };

  return (
    <main className="mx-auto max-w-[900px] px-6 py-10 md:px-10">
      <h1 className="mb-8 font-display text-[26px] font-semibold text-ink">Course Assignment</h1>

      {team.length === 0 ? (
        <EmptyState icon={<Users size={22} />} title="No team members yet" description="Invite team members first from Team Roster." />
      ) : (
        <>
          <Card className="mb-8 p-6">
            <h2 className="mb-4 text-[15px] font-semibold text-ink">Assign a course</h2>
            <div className="flex flex-col gap-4 sm:flex-row sm:items-end">
              <Select label="Team member" options={memberOptions} value={selectedMemberId} onChange={(e) => setSelectedMemberId(e.target.value)} className="flex-1" />
              <Select label="Course" options={courseOptions} value={selectedCourseId} onChange={(e) => setSelectedCourseId(e.target.value)} className="flex-1" />
              <Button onClick={handleAssign}>Assign</Button>
            </div>
          </Card>

          <div className="flex flex-col gap-3">
            {team.map((member) => (
              <Card key={member.id} className="p-4">
                <p className="mb-2 text-[14px] font-semibold text-ink">{member.name}</p>
                {member.assignedCourseIds.length === 0 ? (
                  <p className="text-[12px] text-ink-soft">No courses assigned yet.</p>
                ) : (
                  <div className="flex flex-wrap gap-2">
                    {member.assignedCourseIds.map((courseId) => {
                      const course = DUMMY_COURSES.find((c) => c.id === courseId);
                      const completed = member.completedCourseIds.includes(courseId);
                      return (
                        <Badge key={courseId} variant={completed ? "success" : "default"}>
                          {course?.title ?? courseId} {completed ? "- done" : ""}
                        </Badge>
                      );
                    })}
                  </div>
                )}
              </Card>
            ))}
          </div>
        </>
      )}
    </main>
  );
}